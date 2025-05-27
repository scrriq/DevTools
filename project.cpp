#include "Project.h"

Project::Project() {}

Project::Project(const QString &id, const QString &name, const QString &status,
                 const QString &startDate, const QString &endDate)
    : id(id), name(name), status(status), startDate(startDate), endDate(endDate) {}
