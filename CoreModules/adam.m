function [  net,res,opts ] = adam(  net,res,opts )
%NET_APPLY_GRAD_SGD Summary of this function goes here
%   Detailed explanation goes here

    if ~isfield(opts.parameters,'weightDecay')
        opts.parameters.weightDecay=0;
    end
    
    
    if (~isfield(opts.parameters,'mom2'))
        opts.parameters.mom2=0.999; 
    end
    
    if ~isfield(net,'iterations')
        net.iterations=0;
    end
    
    if ~isfield(opts.results,'lrs')
        opts.results.lrs=[];%%not really necessary
    end
    opts.results.lrs=[opts.results.lrs;gather(opts.parameters.lr)];
    
    if ~isfield(opts.parameters,'eps')
        opts.parameters.eps=1e-8;
    end
    
    net.iterations=net.iterations+1;
   
     for layer=1:numel(net.layers)
        if strcmp(net.layers{layer}.type,'conv')||strcmp(net.layers{layer}.type,'mlp')
            if ~isfield(net.layers{1,layer},'momentum2')
                net.layers{1,layer}.momentum2{1}=net.layers{1,layer}.momentum{1};%initialize
                net.layers{1,layer}.momentum2{2}=net.layers{1,layer}.momentum{2};%initialize
                
            end
        end
     end
     
    mom_factor=(1-opts.parameters.mom.^net.iterations);
    mom_factor2=(1-opts.parameters.mom2.^net.iterations);
    
    
    for layer=1:numel(net.layers)
        if isfield(net.layers{1,layer},'weights')
            
            net.layers{1,layer}.momentum{1}=opts.parameters.mom.*net.layers{1,layer}.momentum{1}+(1-opts.parameters.mom).*res(layer).dzdw;
            net.layers{1,layer}.momentum2{1}=opts.parameters.mom.*net.layers{1,layer}.momentum2{1}+(1-opts.parameters.mom).*res(layer).dzdw.^2;
            net.layers{1,layer}.weights{1}=net.layers{1,layer}.weights{1}-opts.parameters.lr*net.layers{1,layer}.momentum{1} ...
                ./(net.layers{1,layer}.momentum2{1}.^0.5+opts.parameters.eps) .*mom_factor2^0.5./mom_factor ...
                - opts.parameters.weightDecay * net.layers{1,layer}.weights{1};
            
            net.layers{1,layer}.momentum{2}=opts.parameters.mom.*net.layers{1,layer}.momentum{2}+(1-opts.parameters.mom).*res(layer).dzdb;
            net.layers{1,layer}.momentum2{2}=opts.parameters.mom.*net.layers{1,layer}.momentum2{2}+(1-opts.parameters.mom).*res(layer).dzdb.^2;
            net.layers{1,layer}.weights{2}=net.layers{1,layer}.weights{2}-opts.parameters.lr*net.layers{1,layer}.momentum{2} ...
                ./(net.layers{1,layer}.momentum2{2}.^0.5+opts.parameters.eps) .*mom_factor2^0.5./mom_factor;
            
        end
    end
   
end

