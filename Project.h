#ifndef PROJECT_H
#define PROJECT_H

#include <QString>

class Project {
public:
    QString id;
    QString name;
    QString status;
    QString startDate;
    QString endDate;

    Project();
    Project(const QString &id, const QString &name, const QString &status,
            const QString &startDate, const QString &endDate);
};

#endif // PROJECT_H
