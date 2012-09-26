/*
 *  LedMarquee.h
 *  gTar
 *
 *  Created by Marty Greenia on 10/24/10.
 *  Copyright 2010 IncidentTech. All rights reserved.
 *
 */

#import "DeviceController.h"
#include "gTar.h"

class LedMarquee
{
public:
	DeviceController * m_deviceController;

	LedMarquee()
	{
		m_deviceController = new DeviceController();
	}
	
	LedMarquee( DeviceController * deviceController)
	{
		m_deviceController = deviceController;
	}
	
	~LedMarquee()
	{
		if ( m_deviceController != NULL )
		{
			delete m_deviceController;
		}
	}
	
	DeviceController * AbandonDeviceController();
	
	void DisplayGtar();
	void ClearGtar();
	
};