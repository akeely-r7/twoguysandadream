package com.twoguysandadream.dal;

import com.twoguysandadream.core.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.RowCallbackHandler;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Created by andrewk on 3/13/15.
 */
@Repository
public class LeagueDao implements LeagueRepository {

    private final NamedParameterJdbcTemplate jdbcTemplate;

    @Value("${league.findOne}")
    private String findOneQuery;
    @Value("${league.rosterSpots}")
    private String rosterSpotsQuery;
    @Value("${league.findBids}")
    private String findBidsQuery;
    @Value("${league.findRosters}")
    private String findRostersQuery;
    @Value("${league.findTeams}")
    private String findTeamsQuery;

    public void setFindOneQuery(String findOneQuery) {
        this.findOneQuery = findOneQuery;
    }

    @Autowired
    public LeagueDao(NamedParameterJdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override public Optional<League> findOneByName(String name) {

        Optional<LeagueMetadata> metadata = getMetadata(name);

        return metadata.map(this::getLeagueData);
    }

    private League getLeagueData(LeagueMetadata metadata) {

        List<Bid> auctionBoard = getAuctionBoard(metadata.getName(), metadata.getPrevious_league());
        List<Team> teams = getTeams(metadata.getName());
        return new League(-1L, metadata.getName(), getRosterSize(metadata),
            metadata.getSalary_cap(), auctionBoard, teams, isPaused(metadata), metadata.getPrevious_league());
    }

    private boolean isPaused(LeagueMetadata metadata) {

        return metadata.getDraft_status().equalsIgnoreCase("paused");
    }

    private List<Team> getTeams(String name) {

        Map<String,List<RosteredPlayer>> rosters = getRosters(name);

        return jdbcTemplate.query(findTeamsQuery, Collections.singletonMap("leagueName", name),
            new TeamRowMapper(rosters));
    }

    private Map<String,List<RosteredPlayer>> getRosters(String leagueName) {

        RosteredPlayerCallbackHandler handler = new RosteredPlayerCallbackHandler();
        jdbcTemplate.query(findRostersQuery, Collections.singletonMap("leagueName", leagueName),
            handler);

        return handler.getRosters();
    }

    private List<Bid> getAuctionBoard(String leagueName, String previousLeague) {

        Map<String, String> params = new HashMap<>();
        params.put("leagueName", leagueName);
        params.put("previousLeague", previousLeague);

        return jdbcTemplate.query(findBidsQuery, params, new BidRowMapper());
    }

    private int getRosterSize(LeagueMetadata metadata) {

        Sport sport = Sport.valueOf(metadata.getSport().toUpperCase());

        int additionalRosterSpots = jdbcTemplate.queryForObject(rosterSpotsQuery,
            Collections.singletonMap("leagueName", metadata.getName()), Integer.class);

        return sport.getBaseRosterSize() + additionalRosterSpots;
    }

    private Optional<LeagueMetadata> getMetadata(String name) {

        try {
            return Optional.of(jdbcTemplate
                .queryForObject(findOneQuery, Collections.singletonMap("leagueName", name),
                    new BeanPropertyRowMapper<>(LeagueMetadata.class)));
        }
        catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    private String decodeString(String string) {

        try {
            return new String(string.getBytes("ISO-8859-1"), "UTF-8");
        }
        catch (UnsupportedEncodingException e) {

            return string;
        }
    }

    public static class LeagueMetadata {

        private String name;
        private BigDecimal salary_cap;
        private String sport;
        private String draft_status;
        private String previous_league;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public BigDecimal getSalary_cap() {
            return salary_cap;
        }

        public void setSalary_cap(BigDecimal salary_cap) {
            this.salary_cap = salary_cap;
        }

        public String getSport() {
            return sport;
        }

        public void setSport(String sport) {
            this.sport = sport;
        }

        public String getDraft_status() {
            return draft_status;
        }

        public void setDraft_status(String draft_status) {
            this.draft_status = draft_status;
        }

        public String getPrevious_league() {
            return previous_league;
        }

        public void setPrevious_league(String previous_league) {
            this.previous_league = previous_league;
        }
    }

    public class BidRowMapper implements RowMapper<Bid> {

        @Override public Bid mapRow(ResultSet rs, int rowNum) throws SQLException {

            BigDecimal amount = rs.getBigDecimal("price");
            long expirationTime = rs.getLong("time");

            String team = rs.getString("team");

            long id = rs.getLong("playerid");
            String name = decodeString(rs.getString("name"));
            Collection<Position> positions = Collections.singletonList(
                new Position(rs.getString("position")));
            String realTeam = rs.getString("realTeam");
            Player player = new Player(id, name, positions, realTeam);
            String rfaOverride = rs.getString("rfa_override");
            String previousTeam = rs.getString("previousTeam");
            long currentTime = rs.getLong("currentTime");

            return new Bid(team, player, amount, expirationTime, rfaOverride, previousTeam, currentTime);
        }
    }

    public class TeamRowMapper implements RowMapper<Team> {

        private final Map<String,List<RosteredPlayer>> rosters;

        public TeamRowMapper(Map<String, List<RosteredPlayer>> rosters) {
            this.rosters = rosters;
        }

        @Override public Team mapRow(ResultSet rs, int rowNum) throws SQLException {

            String name = rs.getString("name");
            Collection<RosteredPlayer> roster = rosters.getOrDefault(name, Collections.emptyList());
            BigDecimal budgetAdjustment = rs.getBigDecimal("money_plusminus");
            int adds = rs.getInt("num_adds");
            return new Team(-1L,name,roster,budgetAdjustment,adds);
        }
    }

    public class RosteredPlayerCallbackHandler implements RowCallbackHandler {

        private final Map<String,List<RosteredPlayer>> rosters = new HashMap<>();

        @Override public void processRow(ResultSet rs) throws SQLException {

            String team = rs.getString("team");

            long id = rs.getLong("playerid");
            String name = decodeString(rs.getString("name"));
            Collection<Position> positions = Collections.singletonList(
                new Position(rs.getString("position")));
            String realTeam = rs.getString("realTeam");
            Player player = new Player(id, name, positions, realTeam);

            BigDecimal cost = rs.getBigDecimal("price");
            String time = rs.getString("time");
            String rfaOverride = rs.getString("rfa_override");

            RosteredPlayer rosteredPlayer = new RosteredPlayer(player, cost, time, rfaOverride);
            rosters.putIfAbsent(team, new ArrayList<>());
            rosters.get(team).add(rosteredPlayer);
        }

        public Map<String, List<RosteredPlayer>> getRosters() {
            return rosters;
        }
    }

    private enum Sport {

        BASEBALL(8),
        FOOTBALL(6);

        private final int baseRosterSize;
        private Sport(int baseRosterSize) {
            this.baseRosterSize = baseRosterSize;
        }

        public int getBaseRosterSize() {
            return baseRosterSize;
        }
    }
}
