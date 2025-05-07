function image2 = fix_burns(image, spots)
    image2 = image;
    n_avg = 2;
    for k = 1:numel(spots)
        spot = spots{k};
        burn = image2(spot(1):spot(3), spot(2):spot(4));
        for i = spot(2):spot(4)
            neighbor = [image2((spot(1)-n_avg-1):(spot(1)-1), i) image2((spot(3)+1):((spot(3)+n_avg+1)), i)]; 
            fill_val = mean(neighbor, "all");
            image2(spot(1):spot(3), i) = fill_val;
        end
    end
end