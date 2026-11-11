import 'package:flutter/material.dart';
import 'package:flutter_book/notes/note_entry.dart';
import 'package:flutter_book/notes/note_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeNoteModel extends ChangeNotifier implements NoteModel {
  @override
  Note? get entryBeingEdited => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('note type tiles render and change selection on a narrow screen',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ChangeNotifierProvider<NoteModel>(
        create: (_) => _FakeNoteModel(),
        child: const MaterialApp(home: Scaffold(body: NoteEntry())),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(RadioListTile<NoteType>), findsNWidgets(3));
    expect(
      tester.widget<RadioGroup<NoteType>>(find.byType(RadioGroup<NoteType>)).groupValue,
      NoteType.Content,
    );

    await tester.tap(find.text('Audio'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      tester.widget<RadioGroup<NoteType>>(find.byType(RadioGroup<NoteType>)).groupValue,
      NoteType.Audio,
    );
  });
}
