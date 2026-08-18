-- V21: Add profile_photo_url to profiles (Owner entity)
ALTER TABLE profiles ADD COLUMN profile_photo_url VARCHAR(512);
