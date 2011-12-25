class User < ActiveRecord::Base
  include Gravtastic
  is_gravtastic

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessor :stripe_card_token

  has_many :user_repositories
  has_many :repositories, through: :user_repositories
  has_one :credit_card
  belongs_to :plan

  before_create :init_plan

  def self.find_for_github_oauth(data)
    if user = User.find_by_github_uid(data.uid)
      if user.github_token.blank?
        user.email = data.info.email
        user.password = Devise.friendly_token[0, 20]
        user.github_uid = data.uid
        user.github_token = data.credentials.token
        user.name = data.info.name
        user.nickname = data.info.nickname
        user.save
      end
      user
    else # Create a user with a stub password.
      user = User.new(email: data.info.email, password: Devise.friendly_token[0, 20])
      user.github_uid = data.uid
      user.github_token = data.credentials.token
      user.name = data.info.name
      user.nickname = data.info.nickname
      user.save
      user
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.github_data"] && session["devise.github_data"]["user_info"]
        user.email = data["email"]
      end
    end
  end

  def self.current
    Thread.current[:user]
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

  def save_stripe_customer(params)
    if self.stripe_customer_token?
      update_stripe_customer(params)
    else
      create_stripe_customer(params)
    end
  end

  def update_plan(plan_id)
    plan = Plan.find(plan_id)
    customer = Stripe::Customer.retrieve(self.stripe_customer_token)
    customer.update_subscription(plan: plan.identifier)
    self.plan = plan
    save!
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe error while update plan: #{e.message}"
    errors.add :base, "There was a problem when updating plan."
    false
  end

  protected
    def create_stripe_customer(params)
      stripe_params = {description: email, card: params[:stripe_card_token]}
      if params[:plan_id].present?
        plan = Plan.find(params[:plan_id])
        stripe_params.merge(plan: plan.identifier)
      end

      customer = Stripe::Customer.create(description: email, card: params[:stripe_card_token])
      self.stripe_customer_token = customer.id
      self.plan = plan
      save!
      save_credit_card(customer)
    rescue Stripe::InvalidRequestError => e
      logger.error "Stripe error while creating customer: #{e.message}"
      errors.add :base, "There was a problem with your credit card."
      false
    end

    def update_stripe_customer(params)
      customer = Stripe::Customer.retrieve(self.stripe_customer_token)
      customer.card = params[:stripe_card_token]
      customer.save
      self.stripe_customer_token = customer.id
      save!
      save_credit_card(customer)
    rescue Stripe::InvalidRequestError => e
      logger.error "Stripe error while creating customer: #{e.message}"
      errors.add :base, "There was a problem with your credit card."
      false
    end

    def save_credit_card(customer)
      credit_card = self.credit_card || self.build_credit_card
      credit_card.last4 = customer.active_card.last4
      credit_card.card_type = customer.active_card.type
      credit_card.exp_month = customer.active_card.exp_month
      credit_card.exp_year = customer.active_card.exp_year
      credit_card.save
    end

    def init_plan
      self.plan = Plan.free.first
    end
end
