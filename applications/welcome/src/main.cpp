// SPDX-License-Identifier: GPL-3.0-or-later
#include <QApplication>
#include <QDesktopServices>
#include <QFont>
#include <QFrame>
#include <QHBoxLayout>
#include <QLabel>
#include <QIcon>
#include <QMainWindow>
#include <QPushButton>
#include <QSizePolicy>
#include <QVBoxLayout>
#include <QWidget>
#include <QProcess>
#include <QUrl>

#ifndef BIRUNIOS_VERSION
#define BIRUNIOS_VERSION "0.1.0"
#endif

namespace {
QPushButton *makeButton(const QString &text, bool primary = false)
{
    auto *button = new QPushButton(text);
    button->setMinimumHeight(44);
    button->setCursor(Qt::PointingHandCursor);
    button->setStyleSheet(primary
        ? "QPushButton{background:#4d8cd4;color:white;border:0;border-radius:10px;padding:10px 18px;font-weight:600;} QPushButton:hover{background:#397bc2;}"
        : "QPushButton{background:#253c58;color:#eef5fc;border:1px solid #3b5878;border-radius:10px;padding:10px 18px;} QPushButton:hover{background:#304f73;}");
    return button;
}

QFrame *makeCard(const QString &title, const QString &description, QPushButton *button)
{
    auto *card = new QFrame;
    card->setObjectName("card");
    card->setStyleSheet("QFrame#card{background:#1b2d43;border:1px solid #304964;border-radius:14px;}");
    auto *layout = new QVBoxLayout(card);
    layout->setContentsMargins(18, 16, 18, 16);
    layout->setSpacing(9);
    auto *heading = new QLabel(title);
    heading->setStyleSheet("color:#ffffff;font-size:16px;font-weight:600;border:0;background:transparent;");
    auto *detail = new QLabel(description);
    detail->setWordWrap(true);
    detail->setStyleSheet("color:#bacbde;font-size:13px;border:0;background:transparent;");
    layout->addWidget(heading);
    layout->addWidget(detail);
    layout->addStretch(1);
    layout->addWidget(button);
    return card;
}
}

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QApplication::setApplicationName("BiruniOS Welcome");
    QApplication::setOrganizationName("BiruniOS");
    QApplication::setWindowIcon(QIcon::fromTheme("birunios-welcome"));

    QMainWindow window;
    window.setWindowTitle("Welcome to BiruniOS");
    window.resize(860, 650);
    window.setMinimumSize(680, 540);

    auto *central = new QWidget;
    central->setStyleSheet("background:#101b2d;color:#eef5fc;");
    auto *root = new QVBoxLayout(central);
    root->setContentsMargins(34, 30, 34, 28);
    root->setSpacing(18);

    auto *eyebrow = new QLabel("B I R U N I O S   /   D E V E L O P E R   P R E V I E W");
    eyebrow->setStyleSheet("color:#80b6e8;font-size:11px;font-weight:700;background:transparent;");
    root->addWidget(eyebrow);

    auto *title = new QLabel("Welcome to BiruniOS.");
    QFont titleFont = title->font();
    titleFont.setPointSize(29);
    titleFont.setWeight(QFont::DemiBold);
    title->setFont(titleFont);
    title->setStyleSheet("color:#ffffff;background:transparent;");
    root->addWidget(title);

    auto *subtitle = new QLabel("A fast, elegant, open Linux desktop designed for everyday work.");
    subtitle->setWordWrap(true);
    subtitle->setStyleSheet("color:#bacbde;font-size:15px;background:transparent;");
    root->addWidget(subtitle);

    auto *notice = new QLabel("This is an experimental preview. Back up important data and report problems before relying on this system.");
    notice->setWordWrap(true);
    notice->setStyleSheet("background:#26384d;color:#f2d9a6;border:1px solid #665638;border-radius:10px;padding:12px;font-size:12px;");
    root->addWidget(notice);

    auto *cards = new QHBoxLayout;
    cards->setSpacing(14);
    auto *settingsButton = makeButton("Open Settings", true);
    QObject::connect(settingsButton, &QPushButton::clicked, [] {
        QProcess::startDetached("systemsettings", {});
    });
    auto *softwareButton = makeButton("Explore Software", true);
    QObject::connect(softwareButton, &QPushButton::clicked, [] {
        QProcess::startDetached("plasma-discover", {});
    });
    auto *docsButton = makeButton("Read Handbook");
    QObject::connect(docsButton, &QPushButton::clicked, [] {
        QDesktopServices::openUrl(QUrl("https://github.com/99code-hub/birunios/tree/main/docs"));
    });
    cards->addWidget(makeCard("Make it yours", "Adjust your display, theme, keyboard, network, and accessibility preferences.", settingsButton));
    cards->addWidget(makeCard("Find applications", "Browse the software sources configured for this BiruniOS installation.", softwareButton));
    cards->addWidget(makeCard("Learn and troubleshoot", "Read installation guidance, known issues, and troubleshooting notes.", docsButton));
    root->addLayout(cards, 1);

    auto *footer = new QLabel(QStringLiteral("BiruniOS %1  ·  Fedora Linux 45 base  ·  KDE Plasma").arg(QStringLiteral(BIRUNIOS_VERSION)));
    footer->setStyleSheet("color:#8fa7c0;font-size:11px;background:transparent;");
    root->addWidget(footer);

    window.setCentralWidget(central);
    window.show();
    return app.exec();
}
