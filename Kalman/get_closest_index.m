function [idx] = get_closest_index(target, array, idx_a, idx_b)

if(array(idx_a) - target >= target - array(idx_b))
    idx = idx_b;
else
    idx = idx_a;
end