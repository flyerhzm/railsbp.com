namespace :stripe do
  desc "synchronize stripe plans"
  task :sync_plans => :environment do
    Stripe::Plan.all.data.each do |stripe_plan|
      plan = Plan.find_or_initialize_by_identifier(stripe_plan.id)

      plan.identifier = stripe_plan.id
      plan.name = stripe_plan.name
      plan.interval = stripe_plan.interval
      plan.livemode = stripe_plan.livemode
      plan.trial_period_days = stripe_plan.respond_to?(:trial_period_days) ? stripe_plan.trial_period_days : 0
      plan.amount = stripe_plan.amount

      plan.save
    end
  end
end
