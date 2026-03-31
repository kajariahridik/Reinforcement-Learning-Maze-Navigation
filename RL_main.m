clc
clear all
close all
% load qeval.mat
load task1.mat
% reward = qevalreward;
runs = 10; % number of runs
max_trials = 3000; % maximum trials
p_max = 100; % minimum number of grids to be navigated before stopping

count = 0;
execution_times = []; % list of execution times
track_trials = []; % number of trials for each run
% Start the runs
for i = 1:runs
    tic
    % Initialization
    Q = zeros(100, 4);
    trial = 1;
    error_threshold = 0.005;
    
    while trial <= max_trials % condition for termination of each run
        
        gamma = 0.95; % Change the discount factor
        % Parameters initialization
        eps_k = 1; 
        Q0 = Q;
        alp_k = eps_k;     
        s_k = 1;
        k = 1;
        while (alp_k > error_threshold) % termination condition for each trial

            % probability functions
            eps_k = 250/(250+k);
            
            alp_k = eps_k;
            k = k+1;
            
            % Find the best action at a state
            n = [1,2,3,4];
            n(reward(s_k,:) == -1)=[]; % remove action that gives reward -1
            [~,a_max] = max(Q(s_k,n)); % find highest rewarding action
            a_max = n(a_max);
            rand_num = rand(1);
            if rand_num > eps_k                     % exploitation
                a_k = a_max;
            else                                    % exploration
                n(n==a_max) = [];
                rand_index = randperm(length(n)); % random action selection
                a_k = n(rand_index(1)); 
            end

             % Get new state
            if a_k == 1 % up
                s_k_new = s_k-1;    
            elseif a_k == 2 % right
                s_k_new = s_k+10;
            elseif a_k == 3 % down
                s_k_new = s_k+1;
            elseif a_k == 4 % left
                s_k_new = s_k-10;
            end
    
            % Update Q-value
            r = reward(s_k, a_k);
            Q(s_k, a_k) = Q(s_k, a_k)+alp_k*(r+gamma*max(Q(s_k_new, :))-Q(s_k, a_k));
            
            % Move to the next state
            s_k = s_k_new;

            % Termination condition: robot reaches state 100
            if s_k == 100 
                break;
            end

        end
        trial = trial+1; % go to next trial

        % termination condition: Q-value converges
        if max(abs(Q-Q0),[],"all") < error_threshold 
            break;
        end
    end
    track_trials(i) = trial;
    
    % Get number of runs and execution times for all the runs where the
    % robot reaches state 100
    if s_k == 100
        count = count+1;
        time = toc;
        execution_times(i) = time;
    end
end
count % number of goal reaching runs

% average execution time of goal reaching runs
avg_exec_time = sum(execution_times)/count 

%% Plot number of trials
runs = 1:10;
eqn = '250/(250+k)';
plot(runs,track_trials)
hold on
for i=1:10
    if execution_times(i) ~= 0 
        plot(i,track_trials(i),'MarkerSize',8,'Marker','*')
    end
end
title([eqn,', discount factor = ',num2str(gamma)])
hold off

%% function plot
figure(2)
stp = 1:200;
epsilon1 = 250./(250+stp);
eqn = '250/(250+k)';

%% plot all actions (optimal policy)
[~,policy] = max(Q,[],2);
figure()
hold on
for i = 1:10
    for j = 1:10
       
        if policy(10*(i-1)+j) == 1
            plot(i-0.5,10-j+0.5,'Marker','^','MarkerEdgeColor','m')
        elseif policy(10*(i-1)+j) == 2
            plot(i-0.5,10-j+0.5,'Marker','>','MarkerEdgeColor','k')
        elseif policy(10*(i-1)+j) == 3
            plot(i-0.5,10-j+0.5,'Marker','v','MarkerEdgeColor','b')
        elseif policy(10*(i-1)+j) == 4
            plot(i-0.5,10-j+0.5,'Marker','<','MarkerEdgeColor','g')
        end
    end
end
grid on
title('optimal actions at each state')
hold off

%% plot optimal path
figure()
hold on
row = 0.5;col = 9.5;
i = 1;p = 0;
qevalstates = [];
total_reward = 0;
while i<=100
    if i == 100 || p == p_max
        plot(row,col,'Marker','x','MarkerEdgeColor','r')
        break;
    end
    if policy(i) == 1
        plot(row,col,'Marker','^','MarkerEdgeColor','m')
        i = i-1; 
        col = col + 1;
     
        
    elseif policy(i) == 2
        plot(row,col,'Marker','>','MarkerEdgeColor','k')
        i = i+10;
        row = row + 1;
      
    elseif policy(i) == 3
        plot(row,col,'Marker','v','MarkerEdgeColor','b')
        i = i+1; 
        col = col - 1;
       
   elseif policy(i) == 4
        plot(row,col,'Marker','<','MarkerEdgeColor','g')
        i = i-10; 
        row = row - 1;
        
    end
    p = p+1;
    total_reward = total_reward + reward(i,policy(i));
    qevalstates(p) = policy(i);
end
title(sprintf('optimal path, reward = %.2f',total_reward))
grid on
hold off
qevalstates