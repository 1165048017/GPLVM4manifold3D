function model = fgplvmExpandParam(model, params)

% FGPLVMEXPANDPARAM Expand a parameter vector into a GP-LVM model.
%
%	Description:
%
%	FGPLVMEXPANDPARAM(MODEL, PARAMS) takes an FGPLVM structure and a
%	vector of parameters, and fills the structure with the given
%	parameters. Also performs any necessary precomputation for
%	likelihood and gradient computations, so can be computationally
%	intensive to call.
%	 Arguments:
%	  MODEL - the FGPLVM structure to put the parameters in.
%	  PARAMS - parameter vector containing the parameters to put in the
%	   FGPLVM structure.
%	MODIFICATION: Carl Henrik Ek, 2009
%	
%
%	See also
%	FGPLVMCREATE, FGPLVMEXTRACTPARAM, MODELEXPANDPARAM


%	Copyright (c) 2005, 2006, 2009 Neil D. Lawrence
% 	fgplvmExpandParam.m CVS version 1.6
% 	fgplvmExpandParam.m SVN version 291
% 	last update 2009-03-04T22:08:40.000000Z


startVal = 1;
if isfield(model, 'back') & ~isempty(model.back)
  endVal = model.back.numParams;
  model.back = modelExpandParam(model.back, params(startVal:endVal));
  model.X = modelOut(model.back, model.y);
else
  endVal = model.N*model.q;
  model.X = reshape(params(startVal:endVal), model.N, model.q);
end
startVal = endVal+1;
endVal = endVal + model.kern.nParams;

switch model.approx
 case 'ftc'
  endVal = endVal;
 case {'dtc', 'dtcvar', 'fitc', 'pitc'}
  if model.fixInducing
    % account for beta attached to the end.
    endVal = endVal + 1; 
    % X_u values are taken from X values.
    model.X_u = model.X(model.inducingIndices, :);
  else
    % Parameters include inducing variables and beta.
    endVal = endVal + model.q*model.k + 1;
  end

 otherwise
  error('Unknown approximation type.')
end
if model.learnScales
  endVal = endVal + model.d;
end
model = gpExpandParam(model, params(startVal:endVal));


% Give parameters to dynamics if they are there.
if isfield(model, 'dynamics') & ~isempty(model.dynamics)
  startVal = endVal + 1;
  endVal = length(params);

  % Fill the dynamics model with current latent values.
  model.dynamics = modelSetLatentValues(model.dynamics, model.X);

  % Update the dynamics model with parameters (thereby forcing recompute).
  model.dynamics = modelExpandParam(model.dynamics, params(startVal:endVal));
end

% Constraints
if(isfield(model,'constraints')&&~isempty(model.constraints))
  for(i = 1:1:model.constraints.numConstraints)
    model.constraints.comp{i} = constraintExpandParam(model.constraints.comp{i},model.X);
  end
end
