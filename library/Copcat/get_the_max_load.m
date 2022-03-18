function [Shearmax,MomentMax]=get_the_max_load(Markov_matrix)
%min
total_shear(:,1)= Markov_matrix(:,4)-Markov_matrix(:,3)/2;
total_moment(:,1)= -Markov_matrix(:,2)-Markov_matrix(:,1)/2;
%max
total_shear(:,2)= Markov_matrix(:,4)+Markov_matrix(:,3)/2;
total_moment(:,2)= -Markov_matrix(:,2)+Markov_matrix(:,1)/2;


[max_shear(1,:), index(1,:)]=max(abs(total_shear(:,1)));
[max_shear(2,:), index(2,:)]=max(abs(total_shear(:,2)));


[max_moment(1,:), index(1,:)]=max(abs(total_moment(:,1)));
[max_moment(2,:), index(2,:)]=max(abs(total_moment(:,2)));

[Shearmax.shear,inds]=max(max_shear(:,1));
Shearmax.moment=-abs(total_moment(index(inds), inds));

[MomentMax.moment,indm]=max(max_moment);
MomentMax.shear=abs(total_shear(index(indm),indm));
MomentMax.moment=-MomentMax.moment;

end 

