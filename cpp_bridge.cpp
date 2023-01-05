#include <lua.hpp>
#include <memory>
#include <cstdint>

int32_t math_add(int32_t x, int32_t y) {
  return x + y;
}

int32_t math_subtract(int32_t x, int32_t y) {
  return x - y;
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
  
  lua_register(L, "math_add", math_add);

	// Register math_subtract function in global environment
	lua_register(L, "math_subtract", math_subtract);

  lua_pushcfunction(L, run_cpp_code);
  lua_setglobal(L, "run_cpp_code");
  lua_close(L);
  return 0;
}
