# Multithreaded-Core-Data

![multithreadedcoredata](https://cloud.githubusercontent.com/assets/26578409/24807478/f2e48226-1bd5-11e7-8fbd-a73b59ee12de.gif)

Concurrency is the ability to work with the data on more than one queue at the same time. For persistent stores using WAL journal_mode (the default in Core Data), the NSPersistentStoreCoordinator also supports 1 writer concurrently with multiple readers. For example, a UI context can fetch data concurrently with a single background context importing changes.

In this example we are reading data from JSON file, then we are saving more then 50K data to Core data. And finally showing it by fetching it from DB.
It saves data in background and while doing that it also fetches data.
