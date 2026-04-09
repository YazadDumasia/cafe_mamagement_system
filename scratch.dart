import 'dart:async';

Future<T> execute<T>(Future<T> Function() operation) async {
  try {
    return await operation();
  } catch (e) {
    return null as T;
  }
}

Future<int?> getInt() async => 5;
Future<void> getVoid() async {}

Future<int?> wrapperInt() async {
  return await execute(() async => await getInt());
}

Future<void> wrapperVoid() async {
  return await execute(() async => await getVoid());
}

void main() async {
  print(await wrapperInt());
  await wrapperVoid();
  print('Done');
}
