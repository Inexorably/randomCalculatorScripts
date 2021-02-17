%%

%Some input vars.
internaliterations = 30000;
numSlots = 10;
baseItemValue = 0.5; %In b
cost10 = 0.001;
cost30 = 0.01;
costWS = 0.5;

%Preallocate to save results.  First dimension is the slots raw 30'd (0:4),
%second is slots ws 30'd (0:4).
results = cell(5, 5);

%Initialize the struct fields.
for ii=1:5
    for jj=1:5
        results{ii, jj} = struct('valueUsed', 0, 'passes', 0, 'costPerSuccess', 0);
    end
end

%Loop over some different conditions.
for slotsRaw30=0:4
   for slotsWS30=0:4
       %For each condition, do some simulation runs.
       for ii=1:internaliterations
           %Initialize a clean wep.
           temp.numSlots = numSlots;
           temp.valueUsed = baseItemValue;
           temp.passes = 0; %Slots passed.

           %If failed a slot without ws or boomed.
           temp.fail = false;

           %Begin scrolling per the conditions given by indexes.

           %Begin raw 30s.
           while (temp.passes < slotsRaw30 && ~temp.fail)
              %Use a 30 without a ws.
              temp.valueUsed = temp.valueUsed + cost30;
              %If pass:
              if (rand < 0.3)
                  temp.passes = temp.passes + 1;
              else
                  %With raw 30, losing a slot should trash the value,
                  %so put this onto a loss.
                  temp.fail = true;
              end
           end

           %Begin ws 30s.
           while (temp.passes < slotsRaw30+slotsWS30 && ~temp.fail)
              %Use a 30 with a ws.
              temp.valueUsed = temp.valueUsed + cost30 + costWS;
              %If pass:
              if (rand < 0.3)
                  temp.passes = temp.passes + 1;
              elseif (rand < 0.5)
                  %50% chance of boom when fail.
                  temp.fail = true;
              end
           end

           %Begin ws 10s, do the rest of the slots.
           while (temp.passes < numSlots && ~temp.fail)
              %Use a 10% with a ws.
              temp.valueUsed = temp.valueUsed + cost30 + costWS + cost10;
              %If pass:
              if (rand < 0.1)
                  temp.passes = temp.passes + 1;
              end
           end
          
           %Save the results of this run (if passed, and meso value used in
           %the process.  Note that we offste index by one because matlab
           %indexing starts at 1 (lol).
           results{slotsRaw30+1, slotsWS30+1}.valueUsed = results{slotsRaw30+1, slotsWS30+1}.valueUsed+temp.valueUsed;
           
           %Track if run passed to allow for efficiency check.
           if (~temp.fail)
               results{slotsRaw30+1, slotsWS30+1}.passes = results{slotsRaw30+1, slotsWS30+1}.passes+1;
           end
       end
       %Analyze the results of each run.  Find the average valueUsed / passes.
       results{slotsRaw30+1, slotsWS30+1}.costPerPass = results{slotsRaw30+1, slotsWS30+1}.valueUsed/results{slotsRaw30+1, slotsWS30+1}.passes;
   end   
end

%Plot the results.
figure
title(['Cost per successful + ' num2str(numSlots) ' ' num2str(internaliterations) ' runs per condition with ' num2str(baseItemValue) 'b item base cost'])
hold on
grid on
for ii=1:5
    for jj=1:5
        text(ii-1, jj-1, num2str(results{ii,jj}.costPerPass));
    end
end
xlabel('Slots raw 30d')
ylabel('Slots WS 30d')
xlim([-1 5])
ylim([-1 5])
