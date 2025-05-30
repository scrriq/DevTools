#pragma once

#include <QAbstractListModel>
#include <QColor>
#include <QVector>

class GradientModel : public QAbstractListModel {
    Q_OBJECT
    // Тип градиента — Linear или Radial
    Q_PROPERTY(GradientType gradientType READ gradientType WRITE setGradientType NOTIFY gradientTypeChanged)
    // Угол поворота (в градусах) для линейного градиента
    Q_PROPERTY(int angle READ angle WRITE setAngle NOTIFY angleChanged)
    // «Текущий» цвет, который будет добавлен как новый стоп
    Q_PROPERTY(QColor currentColor READ currentColor WRITE setCurrentColor NOTIFY currentColorChanged)
    // Сериализованный список стопов для удобного чтения в QML
    Q_PROPERTY(QVariantList stopsList READ stopsList NOTIFY stopsChanged)

public:
    enum GradientType { Linear, Radial };
    Q_ENUM(GradientType)

    explicit GradientModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    GradientType gradientType() const;
    int angle() const;
    QColor currentColor() const;

    // Функции управления стопами:
    Q_INVOKABLE void addStop(const QColor &color, int position);
    Q_INVOKABLE void removeStop(int index);
    Q_INVOKABLE void updateStop(int index, const QColor &color, int position);
    Q_INVOKABLE void updateStop(int index, const QString &colorName, int position);
    QVariantList stopsList() const;

public slots:
    // Сеттеры для свойств
    void setGradientType(GradientType type);
    void setAngle(int angle);
    void setCurrentColor(const QColor &color);

signals:
    // Сигналы изменения свойств
    void gradientTypeChanged();
    void angleChanged();
    void currentColorChanged();
    void stopsChanged();

private:
    struct ColorStop {
        QColor color;
        int position;
    };

    QVector<ColorStop> m_stops;
    GradientType m_type = Linear;
    int m_angle = 0;
    QColor m_currentColor = Qt::white;
};
