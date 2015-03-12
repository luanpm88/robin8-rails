class PitchesContact < ActiveRecord::Base
  belongs_to :pitch
  belongs_to :contact
  
  GREETINGS = [
    "Hi",
    "Hello",
    "Salutations",
    "Cheers",
    "Hi there",
    "Hope this finds you well",
    "How do you do"
  ]

  # Email pitch tags are:
  # ["@[First Name]", "@[Last Name]", "@[Summary]",
  # "@[Outlet]", "@[Link]", "@[Title]"]
  #
  # Twitter pitch tags are:
  # [ "@[Handle]", "@[Name]", "@[Random Greeting]", "@[Link]" ]  
  def render_pitch
    link = "http://placeholder-link.com/" # self.pitch.release.link
    
    if [0, 2].include? self.contact.origin # pressr or media_list
      first_name = self.contact.first_name
      last_name = self.contact.last_name
      outlet = self.contact.outlet
      
      title = self.pitch.release.title
      summary_arr = JSON.parse(self.pitch.release.summaries).take(self.pitch.summary_length) 
      summary_str = summary_arr.map{|s| "- #{s}"}.join("\n")
      
      pitch_text = self.pitch.email_pitch
      pitch_text.gsub!('@[First Name]', first_name)
      pitch_text.gsub!('@[Last Name]', last_name)
      pitch_text.gsub!('@[Summary]', summary_str)
      pitch_text.gsub!('@[Outlet]', outlet)
      pitch_text.gsub!('@[Link]', link)
      pitch_text.gsub!('@[Title]', title)
      pitch_text
    elsif self.contact.origin == 1 # twtrland
      handle = "@#{self.contact.twitter_screen_name}"
      name = self.contact.full_name
      random_greeting = GREETINGS.sample
      
      pitch_text = self.pitch.twitter_pitch
      pitch_text.gsub!('@[Handle]', handle)
      pitch_text.gsub!('@[Name]', name)
      pitch_text.gsub!('@[Random Greeting]', random_greeting)
      pitch_text.gsub!('@[Link]', link)
      pitch_text
    else
      raise "Contact origin is not between [0, 1, 2]"
    end
  end
end
