function [idx] = find_closest_value(target, array)
% find_closest_value finds the index of the target inside of a array which is
% in descendent order

start = 1;
last = length(array);
if target <= array(end)
    idx = last;
    return
end

if target >= array(start)
    idx = start;
    return
end
mid = 0;
while(start < last)
    mid = round((last - start)/2) + start;
    if(target == array(mid))
        idx = mid;
        return
    end
    if(target < array(mid))
        if(mid < last && target > array(mid + 1))
            idx = get_closest_index(target, array, mid, mid + 1);
            return 
        end
        start = mid + 1;
    end
    if(target > array(mid))
        if(mid > 1 && target < array(mid - 1))
            idx = get_closest_index(target, array, mid - 1, mid);
            return
        end
        last = mid - 1;
    end
end
idx = mid;