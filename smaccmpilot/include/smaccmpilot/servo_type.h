/* This file has been autogenerated by Ivory
 * Compiler version  Version {versionBranch = [0,1,0,0], versionTags = []}
 */
#ifndef __SERVO_TYPE_H__
#define __SERVO_TYPE_H__
#ifdef __cplusplus
extern "C" {
#endif
#include <ivory.h>
struct servo_result {
    bool valid;
    uint16_t servo[4U];
    uint32_t time;
};

#ifdef __cplusplus
}
#endif
#endif /* __SERVO_TYPE_H__ */