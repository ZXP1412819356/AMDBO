% -----------------------------------------------------------------------------------------------------------
% Enhanced Dung Beetle Optimization with Neighborhood Mutation (ENMDBO)
% Programmed by Mingyang Yu    
% Updated 18 Aug. 2025.                     
%
% The details about ENMDBO are illustrated in the following paper:                                                    
%  Mingyang Yu, et al. "Improved Coverage and Redundancy Management in WSN Using ENMDBO: 
%  An Enhanced Metaheuristic Solution," IEEE Transactions on Network and Service Management (TNSM), 2025.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fMin , bestX, Convergence_curve ] = ENMDBO(N, iter,c,d,dim,fobj)
        
   P_percent = 0.2;    % The proportion of producers (ball-rolling beetles) in the total population       


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pNum = round( N * P_percent );    % Number of producers (ball-rolling group)


lb= c.*ones( 1,dim );    % Lower bound vector
ub= d.*ones( 1,dim );    % Upper bound vector

% ---------------- Initialization -------------------
for i = 1 : N
    x( i, : ) = lb + (ub - lb) .* rand( 1, dim ); % Random initialization within bounds
    fit( i ) = fobj( x( i, : )) ;       % Fitness evaluation
end

max_no_improvement=10;   % Threshold for TTDM (Tolerance Threshold Detection Mutation)
no_improvement_count = 0;
pFit = fit;              % Personal best fitness
pX = x;                  % Personal best positions
XX=pX;    
[ fMin, bestI ] = min( fit );      % Global best fitness
bestX = x( bestI, : );             % Global best position

% ---------------- Main Loop ------------------------
for t = 1 : iter    
       
    [fmax,B]=max(fit);        % Worst solution
    worse= x(B,:);   
 
    % =========================================================
    % Producer update (Ball-rolling beetles)
    % With ECST (Exploring Cosine Similarity Transformation)
    % ---------------------------------------------------------
    for i = 1 : pNum 
        indexj = randi(N);
        a = pX(i,:)-bestX;
        b = pX(indexj,:)-bestX;
        cosValue = sum(a.*b)/((sum(a.^2)^0.5).*(sum(b.^2)^0.5)); % Innovation 1: ECST
        
        if(cosValue<rand)
            % Standard ball-rolling update (towards worse solution + direction perturbation)
            r1=rand(1);
            a=rand(1,1);
            if (a>0.1)
               a=1;
            else
               a=-1;
            end
            x( i , : ) =  pX(  i , :)+0.3*abs(pX(i , : )-worse)+a*0.1*(XX( i , :)); 
        else
            % Alternative rolling strategy with obstacle avoidance (tangent function)
            aaa= randperm(180,1);
            if ( aaa==0 ||aaa==90 ||aaa==180 )
                x(  i , : ) = pX(  i , :);   
            end
            theta= aaa*pi/180;   
            x(  i , : ) = pX(  i , :)+tan(theta).*abs(pX(i , : )-XX( i , :));     
        end
      
        % Boundary check and fitness update
        x(  i , : ) = Bounds( x(i , : ), lb, ub );    
        fit(  i  ) = fobj( x(i , : ));
    end 
    
    % Update best so far
    [ fMMin, bestII ] = min( fit );      
    bestXX = x( bestII, : );             

    R=1-t/iter;    % Dynamic shrinking factor

    % Boundaries around current best
    Xnew1 = bestXX.*(1-R); 
    Xnew2 = bestXX.*(1+R);                    
    Xnew1= Bounds( Xnew1, lb, ub );
    Xnew2= Bounds( Xnew2, lb, ub );

    % Boundaries around global best
    Xnew11 = bestX.*(1-R); 
    Xnew22 = bestX.*(1+R);                     
    Xnew11= Bounds( Xnew11, lb, ub );
    Xnew22 = Bounds( Xnew22, lb, ub );

    % =========================================================
    % Brood ball beetles (reproduction group)
    % ---------------------------------------------------------
    for i = ( pNum + 1 ) :12
        x( i, : )=bestXX+((rand(1,dim)).*(pX( i , : )-Xnew1)+(rand(1,dim)).*(pX( i , : )-Xnew2));
        x(i, : ) = Bounds( x(i, : ), Xnew1, Xnew2 );
        fit(i ) = fobj(  x(i,:)) ;
    end
   
    % =========================================================
    % Larvae (foraging group)
    % With NSMS (Neighborhood Solution Mutation Sharing)
    % ---------------------------------------------------------
    for i = 13: 19
        if rand<0.5
            % Standard larvae update
            x( i, : )=pX( i , : )+((randn(1)).*(pX( i , : )-Xnew11)+((rand(1,dim)).*(pX( i , : )-Xnew22)));
            x(i, : ) = Bounds( x(i, : ),lb, ub);
            fit(i ) = fobj(  x(i,:)) ;
        else
            % Innovation 2: NSMS (use neighborhood best to mutate)
            [sorted_objctive, sorted_indexes] = sort(fit);
            current_solution = find(sorted_indexes == i);  
            near_solution_postion = current_solution - 1;  
            if near_solution_postion == 0
                near_solution_postion = 1;
            end
            near_solution = sorted_indexes(near_solution_postion);
            x( i, : )=bestX-rand*(bestX-pX( near_solution  , : ));
            x(i, : ) = Bounds( x(i, : ),lb, ub);
            fit(i ) = fobj(  x(i,:)) ;
        end
    end
  
    % =========================================================
    % Thieves (stealing group)
    % ---------------------------------------------------------
    for j = 20 : N
        x( j,: )=bestX+randn(1,dim).*((abs(( pX(j,:  )-bestXX)))+(abs(( pX(j,:  )-bestX))))./2;
        x(j, : ) = Bounds( x(j, : ), lb, ub );
        fit(j ) = fobj(  x(j,:)) ;
    end
  
    % ---------------- Update Leader -------------------
    [current_best_score, idx] = min(fit);
    if current_best_score < fMin
        fMin= current_best_score;
        bestX =  x(idx, :);
        no_improvement_count = 0;
    else
        no_improvement_count = no_improvement_count + 1;
    end

    % =========================================================
    % TTDM (Tolerance Threshold Detection Mutation)
    % Triggered when no improvement for max_no_improvement iterations
    % ---------------------------------------------------------
    if (no_improvement_count >= max_no_improvement)
        for i = 1:N
            step_size = (t/iter^(rand)).* randn(1, dim) ; % Random step size
            mutation_vector =  step_size.*x(i,:);
            x(i, :) = bestX +rand* mutation_vector;
            x(i, :) = min(max( x(i, :), lb), ub); % Boundary check
        end
    end
 
    % ---------------- Personal Best Update -------------------
    for i = 1 : N 
        if ( fit( i ) < pFit( i ) )
            pFit( i ) = fit( i );
            pX( i, : ) = x( i, : );
        end
        if( pFit( i ) < fMin )
            fMin= pFit( i );
            bestX = pX( i, : );
        end
    end
  
    Convergence_curve(t)=fMin; % Record convergence curve
  
end

% ---------------- Bounds Handling -------------------
function s = Bounds( s, Lb, Ub)
  temp = s;
  I = temp < Lb;  temp(I) = Lb(I);  
  J = temp > Ub;  temp(J) = Ub(J);  
  s = temp;

function S = Boundss( SS, LLb, UUb)
  temp = SS;
  I = temp < LLb; temp(I) = LLb(I);  
  J = temp > UUb; temp(J) = UUb(J);  
  S = temp;
%---------------------------------------------------------------------------------------------------------------------------
