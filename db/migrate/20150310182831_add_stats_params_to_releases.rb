class AddStatsParamsToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :characters_count, :integer, default: 0
    add_column :releases, :words_count, :integer, default: 0
    add_column :releases, :sentences_count, :integer, default: 0
    add_column :releases, :paragraphs_count, :integer, default: 0
    add_column :releases, :adverbs_count, :integer, default: 0
    add_column :releases, :adjectives_count, :integer, default: 0
    add_column :releases, :nouns_count, :integer, default: 0
    add_column :releases, :organizations_count, :integer, default: 0
    add_column :releases, :places_count, :integer, default: 0
    add_column :releases, :people_count, :integer, default: 0
  end
end
