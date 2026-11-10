#
# Generated file, do not edit.
#

list(APPEND FLUTTER_PLUGIN_LIST
<<<<<<< HEAD
=======
<<<<<<< HEAD
=======
<<<<<<< HEAD
>>>>>>> ebd57116e11e72da1fbd1c66dea9ea5086987cfc
>>>>>>> 05e58df6e3d75a564df21426f3a5a29c04c3f519
  flutter_tts
  permission_handler_windows
  speech_to_text_windows
)

list(APPEND FLUTTER_FFI_PLUGIN_LIST
  jni
<<<<<<< HEAD
=======
<<<<<<< HEAD
=======
=======
)

list(APPEND FLUTTER_FFI_PLUGIN_LIST
>>>>>>> 54e7449a60bff342984682161a48f5b30cac1d03
>>>>>>> ebd57116e11e72da1fbd1c66dea9ea5086987cfc
>>>>>>> 05e58df6e3d75a564df21426f3a5a29c04c3f519
)

set(PLUGIN_BUNDLED_LIBRARIES)

foreach(plugin ${FLUTTER_PLUGIN_LIST})
  add_subdirectory(flutter/ephemeral/.plugin_symlinks/${plugin}/windows plugins/${plugin})
  target_link_libraries(${BINARY_NAME} PRIVATE ${plugin}_plugin)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES $<TARGET_FILE:${plugin}_plugin>)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${plugin}_bundled_libraries})
endforeach(plugin)

foreach(ffi_plugin ${FLUTTER_FFI_PLUGIN_LIST})
  add_subdirectory(flutter/ephemeral/.plugin_symlinks/${ffi_plugin}/windows plugins/${ffi_plugin})
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${ffi_plugin}_bundled_libraries})
endforeach(ffi_plugin)
