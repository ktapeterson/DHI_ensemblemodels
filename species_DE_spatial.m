function [tout,yout] = species_DE_spatial(dt,Tmax,n,RI,A,r,D,DispersalStarts,OrderData,TolerableDecrease)

% This function applies a forward Euler solution to the spatial reintroduction problem
% on Dirk Hartog Island.
%
% Inputs:
%   dt -   timestep size
%   Tmax - final simulation time
%   ni -   initial population size
%   A -    species interaction matrix (at any point in space)
%   r -    intrinsic growth rates
%   D -    dispersal matrix
%   RI -   vector of reintroduction sizes

% Construct the timeline
CurrentTime = 2016;
tout = CurrentTime;
Inflation = 10; % This is the time-scaling used to match growth rate constraints
Timesteps = Tmax./dt*Inflation;

OrderData(4,:) = zeros(1,size(OrderData,2));
for t = 1:Timesteps
    
    % Simulate the internal community dynamics of each region separately
    for Region = 1:5
        n(:,t+1,Region) = n(:,t,Region) + dt.*(n(:,t,Region).*r + (A*n(:,t,Region)).*n(:,t,Region));
    end
    
    % If any reintroduced populations are lower than a tolerance of their reintroduction level, we force them to decline
    F = find(sum(n(1:13,t+1,:),3)' < RI*TolerableDecrease & sum(n(1:13,t,:),3)' > 0);
    for f = 1:length(F)
        % Drive a 5% decline per timestep. Overwrite previous dynamics
        n(F(f),t+1,:) = n(F(f),t,:)*0.95;
    end
    
    % Simulate the introduction in the appropriate year and location
    F = find(abs(OrderData(2,:) - CurrentTime) < 1e-2); % Are we close to any reintroduction times?
    if isempty(F) == 0
        for f = 1:length(F)
            ThisRow = OrderData(:,F(f))';
            if ThisRow(4) == 0 % If this translocation has not already been applied
                n(ThisRow(1),t+1,ThisRow(3)) = n(ThisRow(1),t+1,ThisRow(3)) + RI(ThisRow(1));
                OrderData(4,F(f)) = 1;
            end
        end
    end
    
    for sp = 1:13
        
        % If we've waited long enough post-translocation for this species
        if CurrentTime >= DispersalStarts(sp)
            
            % Calculate the dispersal between regions 1 & 2
            d12 = n(sp,t+1,1).*D{1}(1,sp);
            d21 = n(sp,t+1,2).*D{1}(1,sp);
            
            % Implement the dispersal between regions 2 & 3
            d23 = n(sp,t+1,2).*D{1}(2,sp);
            d32 = n(sp,t+1,3).*D{1}(2,sp);
            
            % Implement the dispersal between regions 3 & 4
            d34 = n(sp,t+1,3).*D{1}(3,sp);
            d43 = n(sp,t+1,4).*D{1}(3,sp);
            
            % Implement the dispersal between regions 4 & 5
            d45 = n(sp,t+1,4).*D{1}(4,sp);
            d54 = n(sp,t+1,5).*D{1}(4,sp);
            
            n(sp,t+1,1) = n(sp,t+1,1) - d12 + d21;
            n(sp,t+1,2) = n(sp,t+1,2) + d12 - d21;
            n(sp,t+1,2) = n(sp,t+1,2) - d23 + d32;
            n(sp,t+1,3) = n(sp,t+1,3) + d23 - d32;
            n(sp,t+1,3) = n(sp,t+1,3) - d34 + d43;
            n(sp,t+1,4) = n(sp,t+1,4) + d34 - d43;
            n(sp,t+1,4) = n(sp,t+1,4) - d45 + d54;
            n(sp,t+1,5) = n(sp,t+1,5) + d45 - d54;
        end
    end
    
    % Update the current time
    CurrentTime = CurrentTime + dt/Inflation;
    tout = [tout CurrentTime];
end
yout = n;

if sum(OrderData(4,:)==0) > 0
    disp('Some species were not translocated, change check')
    keyboard
end





