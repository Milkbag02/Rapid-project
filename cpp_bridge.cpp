#include <lua.hpp>
#include <memory>
#include <cstdint>
#include <lauxlib.h>
#include <cmath>

int compute_cos(double x) {
  return std::cos(x);
}

int compute_sin(double x) {
  return std::sin(x);
}

int compute_tan(double x) {
  return std::tan(x);
}

int compute_abs(double x) {
  return std::abs(x);
}

int compute_sqrt(double x) {
  return std::sqrt(x);
}

int compute_exp(double x) {
  return std::exp(x);
}

int compute_log(double x) {
  return std::log(x);
}

int compute_log10(double x) {
  return std::log10(x);
}

int compute_pow(double base, double exponent) {
  return std::pow(base, exponent);
}

int compute_deg(double x) {
  return std::degrees(x);
}

int compute_rad(double x) {
  return std::radians(x);
}

int run_cpp_code(lua_State* L) {
  std::string_view cpp_code{ lua_tostring(L, -1) };

  auto compiled_code = compile(cpp_code);

  execute(compiled_code);

  return 0;
}



int main() {
	lua_State* L = luaL_newstate();
  
	luaL_openlibs(L);

	lua_pushcfunction(L, run_cpp_code);
	lua_setglobal(L, "run_cpp_code");
	
	lua_pushcfunction(L, compute_cos)
	lua_setglobal(L, "compute_cos")
	
	lua_pushcfunction(L, compute_sin)
	lua_setglobal(L, "compute_sin")
	
	lua_pushcfunction(L, compute_tan)
	lua_setglobal(L, "compute_tan")
	
	lua_pushcfunction(L, compute_abs)
	lua_setglobal(L, "compute_abs")
	
	lua_pushcfunction(L, compute_sqrt)
	lua_setglobal(L, "compute_sqrt")
	
	lua_pushcfunction(L, compute_exp)
	lua_setglobal(L, "compute_exp")
	
	lua_pushcfunction(L, compute_log)
	lua_setglobal(L, "compute_log")
	
	lua_pushcfunction(L, compute_log10)
	lua_setglobal(L, "compute_log10")
	
	lua_pushcfunction(L, compute_pow)
	lua_setglobal(L, "compute_pow")
	
	lua_pushcfunction(L, compute_deg)
	lua_setglobal(L, "compute_deg")
	
	lua_pushcfunction(L, compute_rad)
	lua_setglobal(L, "compute_rad")
	
	lua_close(L);
  return 0;
}
