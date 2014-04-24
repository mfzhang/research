function write_diagnostics(DIAGPATH, eyeimage_filename, eyeimage, imagewithnoise, circleiris, circlepupil)

imagewithnoise2 = uint8(imagewithnoise);
imagewithcircles = uint8(eyeimage);

%get pixel coords for circle around iris
[x,y] = circlecoords([circleiris(2),circleiris(1)],circleiris(3),size(eyeimage));
ind2 = sub2ind(size(eyeimage),double(y),double(x));

%get pixel coords for circle around pupil
[xp,yp] = circlecoords([circlepupil(2),circlepupil(1)],circlepupil(3),size(eyeimage));
ind1 = sub2ind(size(eyeimage),double(yp),double(xp));

% Write noise regions
imagewithnoise2(ind2) = 255;
imagewithnoise2(ind1) = 255;
% Write circles overlayed
imagewithcircles(ind2) = 255;
imagewithcircles(ind1) = 255;

w = cd;
cd(DIAGPATH);
imwrite(imagewithnoise2,  [DIAGPATH, eyeimage_filename, '-noise.bmp'],     'bmp');
imwrite(imagewithcircles, [DIAGPATH, eyeimage_filename, '-segmented.bmp'], 'bmp');
cd(w);
