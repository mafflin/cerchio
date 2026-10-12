import Toybox.Complications;
import Toybox.Lang;

//! Comes formatted, e.g. "H 21 / L 12"; adds a degree mark per number
class HighLowKind extends FieldKind {

    function initialize(resourceId as ResourceId?) {
        FieldKind.initialize(resourceId);
    }

    protected function format(value as Complications.Value, complication as Complications.Complication) as String {
        if (!(value instanceof Lang.String)) {
            // Some watches send one number
            return ValueFormat.whole(value) + ValueFormat.DEGREE;
        }

        var characters = value.toCharArray();
        var text = ValueFormat.NOTHING;

        for (var i = 0; i < characters.size(); i++) {
            text += characters[i].toString();

            if (endsNumber(characters, i)) {
                text += ValueFormat.DEGREE;
            }
        }

        return text;
    }

    private function endsNumber(characters as Array<Char>, i as Number) as Boolean {
        if (!isDigit(characters[i])) {
            return false;
        }

        var next = i + 1;

        if (next >= characters.size()) {
            return true;
        }

        if (isDigit(characters[next])) {
            return false;
        }

        // 21.5 takes one mark
        return !(isSeparator(characters[next])
            && ((next + 1) < characters.size())
            && isDigit(characters[next + 1]));
    }

    private function isDigit(character as Char) as Boolean {
        return (character >= '0') && (character <= '9');
    }

    private function isSeparator(character as Char) as Boolean {
        return (character == '.') || (character == ',');
    }
}
