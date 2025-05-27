#ifndef TASK_H
#define TASK_H

#include <QString>

class Task {
public:
    QString id;
    QString projectId;
    QString name;
    QString status;
    QString startDate;
    QString endDate;

    Task() {}
    Task(const QString &id,
         const QString &projectId,
         const QString &name,
         const QString &status,
         const QString &startDate,
         const QString &endDate)
        : id(id),
        projectId(projectId),
        name(name),
        status(status),
        startDate(startDate),
        endDate(endDate)
    {}
};

#endif // TASK_H
