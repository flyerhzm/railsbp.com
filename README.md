# railsbp.com

[![Build Status](https://secure.travis-ci.org/railsbp/railsbp.com.png)](http://travis-ci.org/railsbp/railsbp.com)

[![Click here to lend your support to: rails-bestpractices.com and make a donation at www.pledgie.com !](https://www.pledgie.com/campaigns/12057.png?skin_name=chrome)](http://www.pledgie.com/campaigns/12057)

railsbp.com provides online rails projects code quality check service,
based on rails_best_practices gem.

Any questions and suggestions are welcome, please contact me: flyerhzm@railsbp.com.

rails_best_practices gem
-----------------------

<https://github.com/railsbp/rails_best_practices>

Setup
-----

1. git clone repository

2. copy all config files and change to proper values

    cp config/database.yml.example config/database.yml
    cp config/githbu.yml.example config/github.yml

3. setup database

    rake db:create && rake db:migrate && rake db:seed

4. generate rails_best_practices config file

    bundle exec rails_best_practices -g

5. generate css sprite

    rake css_sprite:build

6. start server

    rails s

Be attention I can only promise rails_best_practices works well in ruby
1.9.2-p290, so it would be better to run it on that ruby version.
