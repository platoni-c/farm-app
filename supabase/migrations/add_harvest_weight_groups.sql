-- Add harvest weight group columns to crops table
ALTER TABLE crops
ADD COLUMN avg_weight_heavy FLOAT,
ADD COLUMN avg_weight_medium FLOAT,
ADD COLUMN avg_weight_light FLOAT;
