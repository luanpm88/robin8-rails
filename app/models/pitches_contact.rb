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
  # "@[Outlet]", "@[Link]", "@[Title]", "@[Text]"]
  #
  # Twitter pitch tags are:
  # [ "@[Handle]", "@[Name]", "@[Random Greeting]", "@[Link]" ]
  def render_pitch
    link = self.pitch.release.permalink

    host = Rails.application.secrets[:host]
    register_text = @l.t('smart_release.pitch_step.email_panel.kols_register_href_text')
    print register_text

    if [0, 2, 3].include? self.contact.origin # pressr or pressr_weibo or media_list
      first_name = self.contact.first_name
      last_name = self.contact.last_name
      outlet = self.contact.outlet

      title = self.pitch.release.title
      text = self.pitch.release.text

      summary_arr = JSON.parse(self.pitch.release.summaries).take(self.pitch.summary_length)
      summary_str = summary_arr.reject{|s| s.blank?}.map{|s| "<li>#{s}</li>"}.join(" ")

      pitch_text = self.pitch.email_pitch
      pitch_text.gsub!('@[First Name]', first_name)
      pitch_text.gsub!('@[Last Name]', last_name)
      pitch_text.gsub!('@[Summary]', "<ul>#{summary_str}</ul>")
      pitch_text.gsub!('@[Outlet]', outlet)
      pitch_text.gsub!('@[Link]', "<a href='#{link}'>#{link}</a>")
      pitch_text.gsub!('@[Title]', title)
      pitch_text.gsub!('@[Text]', text)
      pitch_text.gsub!('@[KolReghref]', "<a href='http://#{Rails.application.secrets[:host]}/kols/new'>#{register_text}</a>")
#      pitch_text.gsub!("\n", "<br />")
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
      raise "Contact origin is not between [0, 1, 2, 3]"
    end
  end
end
