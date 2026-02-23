# Major-League-Baseball- -Diamond-Queries - Fan-Friendly SQL Edition

[![License: MIT](https://img.shields.io/badge/Code_License-MIT-blue.svg)](LICENSE)
[![Data: CC BY-SA 3.0](https://img.shields.io/badge/Data_License-CC%20BY--SA%203.0-green.svg)](https://creativecommons.org/licenses/by-sa/3.0/)

**Copyright (c) 2026 Danny (CesiumSkater)**

This repository transforms the official **[Lahman Baseball Database](https://sabr.org/lahman-database/)** into an easy-to-explore, fan-focused SQL experience.

The core data is derived from the **Lahman Database Version 2025**. It covers complete batting, pitching, fielding, team standings, managerial records, postseason, awards, and Hall of Fame voting from 1871 through 2025. 

### Why This Exists
Raw Lahman tables are incredibly powerful but structurally dense. They are perfect for data analysts, but often overwhelming for the average baseball fan. This project adds custom SQL enhancements to make querying intuitive and conversational:

* **Views:** Simplified, pre-joined perspectives for career totals, seasonal leaders, and team histories across eras.
* **Stored Procedures:** One-call routines like `GetTopHittersByDecade` or `CompareTwoPlayers`.
* **User-Defined Functions:** Easy calculators for metrics like batting average, OPS, and adjusted stats.
* **Triggers & Events:** Built-in tools for data integrity and auto-updates.

### License Structure & Data Disclaimer
This project operates under a dual license model to respect the original creators of the data. 

1.  **The Code (MIT License):** Database schemas, views, stored procedures, functions, and structural SQL scripts written by Danny (CesiumSkater) are licensed under the MIT License. You are free to use, modify, and distribute this structural code.
2.  **The Data (CC BY-SA 3.0):** The underlying baseball statistics contained within the `INSERT` statements are the intellectual property of the Lahman Baseball Database. This data is provided under the Creative Commons Attribution-ShareAlike 3.0 Unported License. Source data is available at https://sabr.org/lahman-database/.

### Getting Started 
Primary support is for **MySQL 8.0+**. Older versions may work but lack optimizer improvements which cause a large sum of warnings and errors.

1.  **Install MySQL:** Use MySQL Community Server, Docker, or your preferred hosted service.
2.  **Execute the Scripts:** Run the provided SQL files in your environment to build the architecture and populate the tables.

### Contributions
Contributions and bug reports are highly encouraged.
* Fork the repository and submit pull requests for new views or procedures.
* Open GitHub issues for questions or bug tracking.

Contact: Danny (@CesiumSkater) via GitHub.

### Limitations and Liability
This project is provided "as is" without warranties of any kind. In no event shall the author be liable for any claim, damages, or other liability arising from the use of the software or the data. Always cross-verify statistics against official sources.
