library utils;

import 'dart:html';

/**
 * more of less "%02d" of sprintf()
  */
String pad02(num o) {
  return o.toString().padLeft(2, '0');
}

// browser dev utils friendly log for objects
log(obj) {
  window.console.log(obj);
}
