% -----------------------------------------------------------------------------------------------------------
% Dung Beetle Optimizer: (DBO) (demo)
% Programmed by Jian-kai Xue    
% Updated 28 Nov. 2022.                     
%
% This is a simple demo version only implemented the basic         
% idea of the DBO for solving the unconstrained problem.    
% The details about DBO are illustratred in the following paper.    
% (To cite this article):                                                
%  Jiankai Xue & Bo Shen (2022) Dung beetle optimizer: a new meta-heuristic
% algorithm for global optimization. The Journal of Supercomputing, DOI:
% 10.1007/s11227-022-04959-6
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% qqÈº£º869592172
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fMin,bestX , Convergence_curve ] = AMDBO(pop, M,c,d,dim,fobj  )
        
   P_percent = 0.2;    % The population size of producers accounts for "P_percent" percent of the total population size       

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pNum = round( pop *  P_percent );    % The population size of the producers   

lb= c.*ones( 1,dim );    % Lower limit/bounds/     a vector
ub= d.*ones( 1,dim );    % Upper limit/bounds/     a vector
%Initialization
for i = 1 : pop
    x( i, : ) = lb + (ub - lb) .* rand( 1, dim );  
    fit( i ) = fobj( x( i, : ) ) ;                       
end

pFit = fit;                       
pX = x; 
 XX=pX;    
[ fMin, bestI ] = min( fit );      % fMin denotes the global optimum fitness value
bestX = x( bestI, : );             % bestX denotes the global optimum position corresponding to fMin
% Start updating the solutions.
for t = 1 : M    
       
        [fmax,B]=max(fit);
        worse= x(B,:);   
       r2=rand(1);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1 : pNum  
% 1.an obstacle-free rolling strategy integrating adaptive probability and global-best guidance
        if(r2 < 0.5)
            n = 0.05 * exp(-2*(t/M)^2);
            p = exp(-3 * (t/M)^2); 
            if rand < p
                x(i,:) = pX(i,:) + n .* rand(1,dim) .* (bestX - pX(i,:));
            else
                x(i,:) = pX(i,:) .* (1 + n .* randn(1,dim));
            end
       else            
           aaa= randperm(180,1);
           if ( aaa==0 ||aaa==90 ||aaa==180 )
            x(  i , : ) = pX(  i , :);   
           end
         theta= aaa*pi/180;   

       x(  i , : ) = pX(  i , :)+tan(theta).*abs(pX(i , : )-XX( i , :));    % Equation (2)      
        end
        x(  i , : ) = Bounds( x(i , : ), lb, ub );    
        fit(  i  ) = fobj( x(i , : ) );
    end 
 [ fMMin, bestII ] = min( fit );      % fMin denotes the current optimum fitness value
  bestXX = x( bestII, : );             % bestXX denotes the current optimum position 
 % R=1-t/M;                           
 %2.logarithmic-root coupled adaptive decay factor
R = (sqrt(M .* t.^2 + 1) + log(sqrt(M .* t.^2 + 1) + (M / 4) .* t) ./ ((M / 4) .* t)).^(-2/3) .* (1.2 ./ t);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 Xnew1 = bestXX.*(1-R); 
     Xnew2 =bestXX.*(1+R);                    %%% Equation (3)
   Xnew1= Bounds( Xnew1, lb, ub );
   Xnew2 = Bounds( Xnew2, lb, ub );
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     Xnew11 = bestX.*(1-R); 
     Xnew22 =bestX.*(1+R);                     %%% Equation (5)
   Xnew11= Bounds( Xnew11, lb, ub );
    Xnew22 = Bounds( Xnew22, lb, ub );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
   for i = ( pNum + 1 ) :12                  % Equation (4)
     x( i, : )=bestXX+((rand(1,dim)).*(pX( i , : )-Xnew1)+(rand(1,dim)).*(pX( i , : )-Xnew2));
% 3.adaptive dynamic mirror-induced boundary handling strategy
k = exp(-5 * (t / M)^2); 
for d_idx = 1:dim
    if x(i, d_idx) < lb(d_idx)
        x(i, d_idx) = k * (lb(d_idx) + rand * (bestX(d_idx) - lb(d_idx))) + (1 - k) * bestX(d_idx);
    elseif x(i, d_idx) > ub(d_idx)
        x(i, d_idx) = k * (ub(d_idx) - rand * (ub(d_idx) - bestX(d_idx))) + (1 - k) * bestX(d_idx);
    end
end
% ---------------------------------------
   % x(i, : ) = Bounds( x(i, : ), Xnew1, Xnew2 );
  fit(i ) = fobj(  x(i,:) ) ;
   end
  for i = 13: 19                  % Equation (6)
x( i, : )=pX( i , : )+((randn(1)).*(pX( i , : )-Xnew11)+((rand(1,dim)).*(pX( i , : )-Xnew22)));
% 3.adaptive dynamic mirror-induced boundary handling strategy
k = exp(-5 * (t / M)^2); 
for d_idx = 1:dim
    if x(i, d_idx) < lb(d_idx)
        x(i, d_idx) = k * (lb(d_idx) + rand * (bestX(d_idx) - lb(d_idx))) + (1 - k) * bestX(d_idx);
    elseif x(i, d_idx) > ub(d_idx)
        x(i, d_idx) = k * (ub(d_idx) - rand * (ub(d_idx) - bestX(d_idx))) + (1 - k) * bestX(d_idx);
    end
end
       % x(i, : ) = Bounds( x(i, : ),lb, ub);
       fit(i ) = fobj(  x(i,:) ) ;
  end

  for j = 20 : pop                 
      x( j,: ) = bestX + randn(1,dim) .* ((abs(( pX(j,:  )-bestXX))) + (abs(( pX(j,:  )-bestX)))) ./ 2;
%3.adaptive dynamic mirror-induced boundary handling strategy
      k = exp(-5 * (t / M)^2); 
      for d_idx = 1:dim
          if x(j, d_idx) < lb(d_idx)
              x(j, d_idx) = k * (lb(d_idx) + rand * (bestX(d_idx) - lb(d_idx))) + (1 - k) * bestX(d_idx);
          elseif x(j, d_idx) > ub(d_idx)
              x(j, d_idx) = k * (ub(d_idx) - rand * (ub(d_idx) - bestX(d_idx))) + (1 - k) * bestX(d_idx);
          end
      end
      fit(j) = fobj(x(j,:));
  end
   % Update the individual's best fitness vlaue and the global best fitness value
     XX=pX;
    for i = 1 : pop 
        if ( fit( i ) < pFit( i ) )
            pFit( i ) = fit( i );
            pX( i, : ) = x( i, : );
        end
        if( pFit( i ) < fMin )
           % fMin= pFit( i );
           fMin= pFit( i );
            bestX = pX( i, : );
          %  a(i)=fMin;
            
        end
    end
     Convergence_curve(t)=fMin;
end

% Application of simple limits/bounds
function s = Bounds( s, Lb, Ub)
  % Apply the lower bound vector
  temp = s;
  I = temp < Lb;
  temp(I) = Lb(I);
  
  % Apply the upper bound vector 
  J = temp > Ub;
  temp(J) = Ub(J);
  % Update this new move 
  s = temp;
function S = Boundss( SS, LLb, UUb)
  % Apply the lower bound vector
  temp = SS;
  I = temp < LLb;
  temp(I) = LLb(I);
  
  % Apply the upper bound vector 
  J = temp > UUb;
  temp(J) = UUb(J);
  % Update this new move 
  S = temp;
%---------------------------------------------------------------------------------------------------------------------------