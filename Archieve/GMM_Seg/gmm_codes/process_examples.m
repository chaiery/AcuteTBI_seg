
% input CT scan directory
inputCTDir = './Patient 8759994/08012006-061835';
% inputCTDir = './Patient 8759994/08012006-061835';
% inputCTDir = './Patient 8720580/10012006-021009';
% inputCTDir = './05192006 - 073800';

% output processed scan directory
% change
outputDir = [inputCTDir, './Patient 8759994/08012006-061835', inputCTDir, '_processed'];

p = path;
path(path, '../modules');

testAll(inputCTDir, outputDir);

path(p)