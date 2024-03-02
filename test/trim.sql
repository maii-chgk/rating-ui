--This trims a full Postgres backup to leave only data used in tests

drop table auth_group_permissions cascade;
drop table auth_user_groups cascade;
drop table auth_group cascade;
drop table auth_user_user_permissions cascade;
drop table auth_permission cascade;
drop table django_admin_log cascade;
drop table django_content_type cascade;
drop table django_migrations cascade;
drop table django_session cascade;
drop table auth_user cascade;
drop table b.team_lost_heredity cascade;
drop table b.team_rating_by_player cascade;
drop table ndcg cascade;
drop table rosters cascade;
drop table rating_individual_old;
drop table rating_individual_old_details;

delete from b.player_rating
where release_id not in (131, 132);

delete from b.team_rating
where release_id not in (131, 132);

delete from b.tournament_in_release
where release_id not in (131, 132);

delete from b.tournament_result
where tournament_id not in (10294);

delete from tournament_results
where tournament_id not in (10294);

delete from true_dls
where tournament_id not in (10294);

delete from tournament_rosters
where tournament_id not in (10294);

delete from tournaments
where id not in (10294);

delete from base_rosters
where team_id not in (49804);

delete from b.release where id not in (131, 132);

delete from teams
where id not in (select team_id from tournament_rosters where tournament_id = 10294);
delete from teams
where id not in (select team_id from b.team_ranking where release_id in (131, 132) and place <= 1000);

delete from players
where id not in (select player_id from tournament_rosters where tournament_id = 10294);
delete from players
where id not in (select player_id from b.player_ranking where release_id in (131, 132) and place <= 1000);

delete from b.player_rating_by_tournament
where release_id not in (131, 132);

delete from b.player_rating_by_tournament
where player_id not in (select id from players);

refresh materialized view b.player_ranking;
refresh materialized view b.team_ranking;
