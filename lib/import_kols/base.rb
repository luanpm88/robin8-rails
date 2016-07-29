module  ImportKols
  class Base
    @@professsions = nil
    def self.get_profession(name)
      return nil if name.nil?
      if @@professsions.nil?
        @@professsions = {}
        Profession.all.each do |p|
          @@professsions[p.label] = p.id
        end
      end
      @@professsions[name] ||  @@professsions['综合']
    end

  end
end
