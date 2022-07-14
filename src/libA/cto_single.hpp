//
// Generated source code
// Generator version: v4.0.0
// Input file: src/libA/cto_single.inh.lua

#pragma once

//
#include <chrono>
#include <cstdint>
#include <string>
#include <vector>


namespace libA {

// -------------------------------------------------------------------------------------------------

struct CTO_Introduction {
	static constexpr int id{0};

	int userID;
	std::string user_name;
	uint64_t version;

	CTO_Introduction() = default;
	explicit inline CTO_Introduction(int userID, std::string user_name, uint64_t version) : userID(userID), user_name(std::move(user_name)), version(version) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_ClientJoined {
	static constexpr int id{20};

	int userID = -1;
	std::string user_name;
	std::chrono::system_clock::time_point joined_at;
	uint64_t version;

	CTO_ClientJoined() = default;
	explicit inline CTO_ClientJoined(int userID, std::string user_name, std::chrono::system_clock::time_point joined_at, uint64_t version) : userID(userID), user_name(std::move(user_name)), joined_at(joined_at), version(version) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_ClientLeave {
	static constexpr int id{21};

	int userID = -1;

	CTO_ClientLeave() = default;
	explicit inline CTO_ClientLeave(int userID) : userID(userID) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_ClientKick {
	static constexpr int id{22};

	int userID = -1;

	CTO_ClientKick() = default;
	explicit inline CTO_ClientKick(int userID) : userID(userID) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_ChatMessage {
	static constexpr int id{23};

	int userID = -1;
	std::chrono::system_clock::time_point sent_at;
	std::string message;

	CTO_ChatMessage() = default;
	explicit inline CTO_ChatMessage(int userID, std::chrono::system_clock::time_point sent_at, std::string message) : userID(userID), sent_at(sent_at), message(std::move(message)) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_LobbyStatus {
	struct Entry {
		int userID = -1;
		float ping;
		float jitter;
		float packet_loss;

		Entry() = default;
		explicit inline Entry(int userID, float ping, float jitter, float packet_loss) : userID(userID), ping(ping), jitter(jitter), packet_loss(packet_loss) {}
		void save(libv::archive::BinaryOutput& ar) const;
		void load(libv::archive::BinaryInput& ar);
	};

	static constexpr int id{24};

	std::vector<Entry> pings;

	CTO_LobbyStatus() = default;
	explicit inline CTO_LobbyStatus(std::vector<Entry> pings) : pings(std::move(pings)) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_LobbyClose {
	static constexpr int id{25};

	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_FleetSpawn {
	static constexpr int id{30};

	int factionID = -1;
	int fleetID = -1;
	int position;

	CTO_FleetSpawn() = default;
	explicit inline CTO_FleetSpawn(int factionID, int fleetID, int position) : factionID(factionID), fleetID(fleetID), position(position) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_FleetSelect {
	static constexpr int id{31};

	int fleetID = -1;

	CTO_FleetSelect() = default;
	explicit inline CTO_FleetSelect(int fleetID) : fleetID(fleetID) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_FleetSelectAdd {
	static constexpr int id{32};

	int fleetID = -1;

	CTO_FleetSelectAdd() = default;
	explicit inline CTO_FleetSelectAdd(int fleetID) : fleetID(fleetID) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_FleetClearSelection {
	static constexpr int id{33};

	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_FleetSelectBox {
	static constexpr int id{34};

	std::vector<int> fleetIDs;

	CTO_FleetSelectBox() = default;
	explicit inline CTO_FleetSelectBox(std::vector<int> fleetIDs) : fleetIDs(std::move(fleetIDs)) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_FleetMove {
	static constexpr int id{35};

	int target_position;

	CTO_FleetMove() = default;
	explicit inline CTO_FleetMove(int target_position) : target_position(target_position) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_FleetMoveQueue {
	static constexpr int id{36};

	int target_position;

	CTO_FleetMoveQueue() = default;
	explicit inline CTO_FleetMoveQueue(int target_position) : target_position(target_position) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_FleetAttackFleet {
	static constexpr int id{37};

	int targetFleetID = -1;

	CTO_FleetAttackFleet() = default;
	explicit inline CTO_FleetAttackFleet(int targetFleetID) : targetFleetID(targetFleetID) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_FleetAttackFleetQueue {
	static constexpr int id{38};

	int targetFleetID = -1;

	CTO_FleetAttackFleetQueue() = default;
	explicit inline CTO_FleetAttackFleetQueue(int targetFleetID) : targetFleetID(targetFleetID) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_FleetAttackPlanet {
	static constexpr int id{39};

	int targetPlanetID = -1;

	CTO_FleetAttackPlanet() = default;
	explicit inline CTO_FleetAttackPlanet(int targetPlanetID) : targetPlanetID(targetPlanetID) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_FleetAttackPlanetQueue {
	static constexpr int id{40};

	int targetPlanetID = -1;

	CTO_FleetAttackPlanetQueue() = default;
	explicit inline CTO_FleetAttackPlanetQueue(int targetPlanetID) : targetPlanetID(targetPlanetID) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_ClearFleets {
	static constexpr int id{41};

	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_Shuffle {
	static constexpr int id{42};

	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_PlanetSpawn {
	static constexpr int id{43};

	int factionID = -1;
	int fleetID = -1;
	int position;

	CTO_PlanetSpawn() = default;
	explicit inline CTO_PlanetSpawn(int factionID, int fleetID, int position) : factionID(factionID), fleetID(fleetID), position(position) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_ClearPlanets {
	static constexpr int id{44};

	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_TrackView {
	static constexpr int id{50};

	int userID = -1;
	int eye;
	int target;
	int mouse_direction;

	CTO_TrackView() = default;
	explicit inline CTO_TrackView(int userID, int eye, int target, int mouse_direction) : userID(userID), eye(eye), target(target), mouse_direction(mouse_direction) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_CameraWarpTo {
	static constexpr int id{51};

	int userID = -1;
	int target_position;

	CTO_CameraWarpTo() = default;
	explicit inline CTO_CameraWarpTo(int userID, int target_position) : userID(userID), target_position(target_position) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_CameraMovement {
	static constexpr int id{52};

	int userID = -1;
	int eye;
	int target;
	int mouse_direction;

	CTO_CameraMovement() = default;
	explicit inline CTO_CameraMovement(int userID, int eye, int target, int mouse_direction) : userID(userID), eye(eye), target(target), mouse_direction(mouse_direction) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

struct CTO_MouseMovement {
	static constexpr int id{53};

	int userID = -1;
	int mouse_position;
	int mouse_direction;

	CTO_MouseMovement() = default;
	explicit inline CTO_MouseMovement(int userID, int mouse_position, int mouse_direction) : userID(userID), mouse_position(mouse_position), mouse_direction(mouse_direction) {}
	void save(libv::archive::BinaryOutput& ar) const;
	void load(libv::archive::BinaryInput& ar);
};

// -------------------------------------------------------------------------------------------------

} // namespace libA
