# == Schema Information
#
# Table name: game_states
#
#  id              :integer          not null, primary key
#  state           :integer
#  jam_number      :integer
#  period_number   :integer
#  jam_clock_label :string(255)
#  home_id         :integer
#  away_id         :integer
#  game_id         :integer
#  created_at      :datetime
#  updated_at      :datetime
#  jam_clock       :integer
#  period_clock    :integer
#

class GameState < ActiveRecord::Base
  belongs_to :home, class_name: "TeamState"
  belongs_to :away, class_name: "TeamState"
  belongs_to :game

  enum state: [:time_to_derby, :pregame, :jam, :lineup, :team_timeout, :official_timeout, :official_review, :unofficial_final, :final]

  def init_demo!
    self.update_attributes!({
        state: :time_to_derby,
        jam_number: 1,
        period_number: 1,
        jam_clock: 90*60*60*1000,
        period_clock: 30*60*60*1000,
      })
    self.build_home
    self.home.update_attributes!({
        name: "Atlanta Rollergirls",
        initials: "ARG",
        color: "#2082a6",
        logo: "http://placehold.it/350x240",
        points: 0,
        jam_points: 0,
        is_taking_official_review: false,
        is_taking_timeout: false,
        has_official_review: true,
        timeouts: 3
      })
    self.home.jammer.update_attributes!({
        is_lead: false,
        name: "Nattie Long Legs",
        number: "504"
      })
    self.build_away
    self.away.update_attributes!({
        name: "Gotham Rollergirls",
        initials: "GRG",
        color: "#f50031",
        logo: "http://placehold.it/350x240",
        points: 0,
        jam_points: 0,
        is_taking_official_review: false,
        is_taking_timeout: false,
        has_official_review: true,
        timeouts: 3
      })
    self.away.jammer.update_attributes!({
        is_lead: true,
        name: "Bonnie Thunders",
        number: "340"
      })
    self.save
  end

  def jam_clock_label
    state.to_s.humanize.upcase
  end

  def as_json
    super(include: {
          :home => {include: :jammer},
          :away => {include: :jammer},
          :game => {}
        }, methods: [:jam_clock_label])
  end

  def to_json(options = {})
    hash = self.as_json
    hash
    JSON.pretty_generate(hash, options)
  end

  private

  def init_teams
    self.build_home if self.home.nil?
    self.build_away if self.away.nil?
  end
  after_initialize :init_teams
end
