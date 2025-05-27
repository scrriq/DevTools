#pragma once
#include <QString>

namespace DevTools {
enum class State {
    NotStated,
    InProgress,
    Done
};

QString stateToString(State state);
State stringToState(const QString& stateStr);
}
