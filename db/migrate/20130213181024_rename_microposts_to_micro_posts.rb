class RenameMicropostsToMicroPosts < ActiveRecord::Migration
  def change
    rename_table :microposts, :micro_posts
  end
end
