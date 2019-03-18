# Pashto Ligatures

## Ligature Database

The file [ligatures.mat](./ligatures.mat) contains the database of 3999 Pashto ligatures, as
a matlab matrix LIGATURES of size 400-by-400-by-39999. Thus, the individual ligatures
are 400-by-400 images with 8 bit depth.

Ligatures are labeled by names of the original files in which the ligatures appeared.
The labels are available as a cell array labels of size 1-by-3999.

# Scripts

The simple scripts visualize ligatures and do some block processing in preparation
for application of Recurrent Neural Networks.


