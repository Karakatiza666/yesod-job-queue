-- | Cron Job for Yesod
module Yesod.JobQueue.Scheduler where

import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.Monoid ((<>))
import Data.Text (Text, pack)
import System.Cron.Schedule
import Yesod.JobQueue
import Yesod.JobQueue.Types


-- | Cron Scheduler for YesodJobQueue
class (YesodJobQueue master) => YesodJobQueueScheduler master where
    -- | job schedules
    getJobSchedules :: master -> [(Text, JobType master)]

    -- | start schedule
    startJobSchedule :: (MonadIO m) => master -> m ()
    startJobSchedule master = do
        let add (s, jt) = addJob (enqueue master jt) s
        tids <- liftIO $ execSchedule $ mapM_ add $ getJobSchedules master
        liftIO $ print tids

-- | Need by 'getClassInformation'
schedulerInfo :: YesodJobQueueScheduler master => master ->  JobQueueClassInfo
schedulerInfo m = JobQueueClassInfo "Scheduler" $ map showSchedule $ getJobSchedules m
  where showSchedule (s, jt) = s <> " | " <> pack (show jt)
