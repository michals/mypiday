library pidigits;

import 'dart:html';
import 'dart:convert';
import 'utils.dart' as utils;

/**
 * returns given subsequence od pi digits. startIndex is 0-indexed.
 * getDigits(0, 6) -> "141592"
 * getDigits(2, 6) ->   "159265"
 * Uses precomputed data fetched in chunks.
 */
getPiDigits(int startIndex, int size) async {
  print('-------------- getPiDigits($startIndex, $size) -----------');
  const chunkSize = 10000; // precomputed chunk size
  var firstChunk = (startIndex / chunkSize).floor();
  var lastChunk = ((startIndex + size) / chunkSize).ceil() - 1;
  var chunksNum = (lastChunk - firstChunk) + 1;
  List<String> chunks = new List(chunksNum);
  for (var i = firstChunk; i <= lastChunk; i++) {
    chunks[i - firstChunk] = await _get10kChunk(i);
  }
  return chunks.join('').substring(startIndex % chunkSize).substring(0, size);
}

/**
 * for "810217" (representing 1981/02/17)
 * returns 0-indexed place in Pi digits
 * where this substring starts in Pi digits.
 * It uses precomputed dictionary.
 * All dates in this format are present in first 11M digits of Pi.
 */
dateToIndex(String yymmdd) async {
  var yy = yymmdd.substring(0, 2);
  var str = await HttpRequest.getString('d2i/${yy}-d2i.json');
  var d2i = JSON.decode(str);
  return d2i[yymmdd];
}

/**
 * get single pi digits chunk
 */
_get10kChunk(int index) async {
  var group = utils.pad02(index ~/ 100);
  var paddedIndex = index.toStringAsFixed(0).padLeft(4, '0');
  var url = 'pi10k/$group/pi10k$paddedIndex';
  return await HttpRequest.getString(url);
}