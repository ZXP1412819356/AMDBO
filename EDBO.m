% -----------------------------------------------------------------------------------------------------------
% EDBO
                 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fMin , bestX, Convergence_curve ] =EDBO(N, iter,c,d,dim,fobj)
        
   P_percent = 0.2;    % The population size of producers accounts for "P_percent" percent of the total population size       


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pNum = round( N *  P_percent );    % The population size of the producers   
 % x = initialization4(N, dim, d,c);

lb= c.*ones( 1,dim );    % Lower limit/bounds/     a vector
ub= d.*ones( 1,dim );    % Upper limit/bounds/     a vector
%Initialization
for i = 1 : N
    
    x( i, : ) = lb + (ub - lb) .* rand( 1, dim ); 
    fit( i ) = fobj( x( i, : )) ;                       
end

pFit = fit;                       
pX = x; 
 XX=pX;    
[ fMin, bestI ] = min( fit );      % fMin denotes the global optimum fitness value
bestX = x( bestI, : );             % bestX denotes the global optimum position corresponding to fMin

 % Start updating the solutions.
for t = 1 : iter 
    
    %%
       
        [fmax,B]=max(fit);
        worse= x(B,:);   
       r2=rand(1);
 
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1 : pNum    
        if(r2<0.9)
            r1=rand(1);
          a=rand(1,1);
          if (a>0.1)
           a=1;
          else
           a=-1;
          end
    x( i , : ) =  pX(  i , :)+0.3*abs(pX(i , : )+rand*bestX)+a*0.1*(XX( i , :)); 
       else
            
           aaa= randperm(180,1);
           if ( aaa==0 ||aaa==90 ||aaa==180 )
            x(  i , : ) = pX(  i , :);   
           end
         theta= aaa*pi/180;   
       
       x(  i , : ) = pX(  i , :)+tan(theta).*abs(pX(i , : )-XX( i , :));    % Equation (2)      

        end
        temp = x;
        r5=rand;
        III= temp (i)< lb;
        temp(III)=r5*bestX(III);
        J = temp(i) > ub;
        temp(J)=(1-r5)*bestX(J);
        x = temp;
       
      
%         x(  i , : ) = Bounds( x(i , : ), lb, ub ); 
        
       
        fit(  i  ) = fobj( x(i , : ));
     end 
 [ fMMin, bestII ] = min( fit );      % fMin denotes the current optimum fitness value
  bestXX = x( bestII, : );             % bestXX denotes the current optimum position 

%   R=1-t/iter;
   R=1-rand*(t/iter)^2;

 %
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
%    x(i, : ) = Bounds( x(i, : ), Xnew1, Xnew2 );
   
   temp = x;
        r5=rand;
        III= temp (i)< lb;
        temp(III)=r5*bestX(III);
        J = temp(i) > ub;
        temp(J)=(1-r5)*bestX(J);
        x = temp;
   
   
   
  fit(i ) = fobj(  x(i,:)) ;
   end
   
  for i = 13: 19                  % Equation (6)
       if rand<0.5

        x( i, : )=pX( i , : )+((randn(1)).*(pX( i , : )-Xnew11)+((rand(1,dim)).*(pX( i , : )-Xnew22)));
       else
            I=round(1+rand(1,1));
        x( i, : )=pX(i,:)+ rand(1,1).*(bestXX-I.* pX(i,:));

       
       end
%        x(i, : ) = Bounds( x(i, : ),lb, ub);
       
       temp = x;
        r5=rand;
        III= temp (i)< lb;
        temp(III)=r5*bestX(III);
        J = temp(i) > ub;
        temp(J)=(1-r5)*bestX(J);
        x = temp;
       
       
       fit(i ) = fobj(  x(i,:)) ;
  end
  
  for j = 20 : N                 % Equation (7)
       x( j,: )=bestX+randn(1,dim).*((abs(( pX(j,:  )-bestXX)))+(abs(( pX(j,:  )-bestX))))./2;
%       x(j, : ) = Bounds( x(j, : ), lb, ub );
      
      temp = x;
        r5=rand;
        III= temp (j)< lb;
        temp(III)=r5*bestX(III);
        J = temp(j) > ub;
        temp(J)=(1-r5)*bestX(J);
        x = temp;
      
      
      
      fit(j ) = fobj(  x(j,:) ) ;
  end
   % Update the individual's best fitness vlaue and the global best fitness value
     XX=pX;
    for i = 1 : N 
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

  
