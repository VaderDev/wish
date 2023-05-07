// Created by Vader on 2022.07.10..

#pragma once

#include <chrono>
#include <cstdint>
#include <ostream>
#include <string>
#include <string_view>

// =================================================================================================

namespace libv {

struct version_number {
	uint16_t major = 0; /// Breaking changes
	uint16_t minor = 0; /// Non-breaking additions
	uint16_t patch = 0; /// Bug fix only no changes

public:
	constexpr inline version_number() noexcept = default;
	constexpr inline version_number(uint16_t major, uint16_t minor) noexcept :
			major(major), minor(minor) {}
	constexpr inline version_number(uint16_t major, uint16_t minor, uint16_t patch) noexcept :
			major(major), minor(minor), patch(patch) {}

public:
	template <typename Archive> void serialize(Archive& ar) {
		ar.nvp("major", major);
		ar.nvp("minor", minor);
		ar.nvp("patch", patch);
	}

public:
	[[nodiscard]] constexpr inline auto operator<=>(const version_number&) const = default;

	friend std::ostream& operator<<(std::ostream& os, const version_number& var) {
		return os << var.major << '.' << var.minor << '.' << var.patch;
		//return os << var.major << '.' << var.minor << '.' << var.patch << '.' << var.build;
	}
};

using build_number = uint32_t;

struct build_info {
	libv::version_number version_number;
	std::string version_name; /// Fictional name of the version: "Espionage"
	std::string variant; /// "Branch variant" Development / Beta / Canary / Live
	libv::build_number build_number;
	// std::chrono::utc_clock::time_point build_time;
	std::string build_time;
	std::string build_uuid;

//	... build_number;
//	... build_hash;
//	... build_date / build_time;
//	... git_commit_number;
//	... git_branch;
//	... variant;
//  std::string compiler;
//  std::string build_type;
//  std::chrono::system_clock::time_point build_time;
//	std::optional<libv::hash::SHA1> git_hash;
//
//	? uint8_t stage;
//		Alpha
//		Beta
//		Release candidate
//		Release
//
//		Stable
//
//	WISH_GIT_BRANCH
//	WISH_GIT_COMMIT_HASH
//	WISH_DATE_SHORT WISH_TIME_SHORT
};

//extern BuildInfo build;
//extern libv::build_info build;

} // namespace libv

// =================================================================================================

// extern std::string_view version;
extern libv::build_info build;
