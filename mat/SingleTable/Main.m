clear;

savename = 'data/Chip1_2_to_512';

[Data_working,Pointer_working,R0_working,MR_working,Data_working_ref,Pointer_working_ref,R0_working_ref,MR_working_ref]=working_table(savename);

% non-reference
MR_avg=mean(MR_working);
MR_mis=MR_working-MR_avg;
MR_mis_std=std(MR_working);
MR_mis_max=max(abs(MR_mis));

R0_avg=mean(R0_working);
R0_mis=R0_working-R0_avg;
R0_mis_std=std(R0_working);
R0_mis_max=max(abs(R0_mis));

% reference
MR_avg_ref=mean(MR_working_ref);
MR_mis_ref=MR_working_ref-MR_avg_ref;
MR_mis_std_ref=std(MR_working_ref);
MR_mis_max_ref=max(abs(MR_mis_ref));

R0_avg_ref=mean(R0_working_ref);
R0_mis_ref=R0_working_ref-R0_avg_ref;
R0_mis_std_ref=std(R0_working_ref);
R0_mis_max_ref=max(abs(R0_mis_ref));

T = load(savename);
figure;
hold on;
plot(T.fields,Data_working(1,:),'b');

xlabel('Applied Field (Oe)','FontSize',18);
ylabel('Sensor Res (Ohm)','FontSize',18);
set(gca,'FontSize',18);

set(gcf,'color','w');
hold off





% Extract data from figure
% fig = gcf;
% axObjs = fig.Children;
% dataObjs = axObjs.Children;
% Field = dataObjs(1).XData;
% Res = dataObjs(1).YData;

