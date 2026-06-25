classdef JCLMS < handle
	%JCLMS Summary of this class goes here
	%	Detailed explanation goes here

    properties
        M
        mu
        w
        buffer
    end

    methods

        function obj = JCLMS(M,mu)

            obj.M = M;
            obj.mu = mu;

            obj.w = zeros(M,1);
            obj.buffer = zeros(M,1);

        end

        function [y,e] = update(obj,x,d)

            obj.buffer = [x; obj.buffer(1:end-1)];

            y = obj.w' * conj(obj.buffer);

            e = d - y;

            obj.w = obj.w + obj.mu * obj.buffer * conj(e);

        end

    end

end

