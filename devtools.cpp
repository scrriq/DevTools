#include "devtools.h"

QString DevTools::stateToString(State state) {
    switch (state) {
    case State::NotStated: return "Not Stated";
    case State::InProgress: return "In Progress";
    case State::Done: return "Done";
    }
    return "Unknown";
}

DevTools::State DevTools::stringToState(const QString& stateStr) {
    if (stateStr == "Not Stated") return State::NotStated;
    if (stateStr == "In Progress") return State::InProgress;
    if (stateStr == "Done") return State::Done;
    return State::NotStated;
}
