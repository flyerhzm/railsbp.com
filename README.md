# railsbp.com

<a href='https://pledgie.com/campaigns/12057'><img alt='Click here to lend your support to: rails best practices and make a donation at pledgie.com !' src='https://pledgie.com/campaigns/12057.png?skin_name=chrome' border='0' ></a>

railsbp.com provides online rails projects code quality check service,
based on rails_best_practices gem.

Any questions and suggestions are welcome, please contact me: flyerhzm@railsbp.com.

## rails_best_practices gem

<https://github.com/flyerhzm/rails_best_practices>

## Setup

1.  Clone repository
2.  Copy all config files and change to proper values

        cp config/database.yml.example config/database.yml
        cp config/github.yml.example config/github.yml
        cp config/mailers.yml.example config/mailers.yml

3. Setup database

        rake db:create && rake db:migrate && rake db:seed

4. Generate CSS sprite


        rake css_sprite:build

5. Start server

        rails s


I can only promise `rails_best_practices` works well in ruby
1.9.2-p290 and 1.9.3-p125, so it would be better to run it on that ruby version.
