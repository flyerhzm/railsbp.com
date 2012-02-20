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

2. copy all config/*.yml.example to config/*.yml, and change to what you want

3. setup database

    rake db:create && rake db:migrate && rake db:seed

4. generate css sprite

    rake css_sprite:build

5. start server

    rails s
